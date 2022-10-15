import { Inject } from '@nestjs/common';
import {
	Constructor,
	RecursivePartial,
} from 'sequelize-typescript/dist/shared/types';
import { EventsService, TriggeredEvent } from './events/events.service';
import { Event } from '@sudonym/models';
import { Callback } from '../helper/callback';
import { FindOptions, Op, UniqueConstraintError } from 'sequelize';
import { RequestType } from 'helper/parse-request.decorator';
import { BaseModel } from './base.model';
import { Subject } from 'rxjs';

type ModelType<T> = Constructor<T> & typeof BaseModel;

export interface TControllerAndService<TModel> {
	onModuleInit(): any;
	findOne(id): Promise<TModel>;
	create(params: RecursivePartial<TModel>): Promise<TModel>;
	update(id, params: RecursivePartial<TModel>): Promise<TModel>;
	list(param: FindOptions): Promise<{
		data: TModel[];
		metadata: {
			count: number;
		};
	}>;
}
export interface TBaseService<TModel> extends TControllerAndService<TModel> {
	beforeCreate: Callback<TModel>;
	afterCreate: Callback<CreatedOrUpdated<TModel>>;
	onAfterCreated: Subject<TModel>;
	beforeUpdate: Callback<TModel>;
	afterUpdate: Callback<CreatedOrUpdated<TModel>>;
	onAfterUpdated: Subject<TModel>;
	getUserIds: (id: number | string, scope?: string) => Promise<string[]>;
	createOrUpdate: (params) => Promise<TModel>;
}

export interface CreatedOrUpdated<TModel> {
	entity: TModel;
	params: RecursivePartial<TModel>;
}

export const BaseService = <TModel extends BaseModel>(
	repository: ModelType<TModel>
): Constructor<TBaseService<TModel>> => {
	class X {
		beforeCreate = new Callback<TModel>();
		afterCreate = new Callback<CreatedOrUpdated<TModel>>();
		onAfterCreated = new Subject<TModel>();
		beforeUpdate = new Callback<TModel>();
		afterUpdate = new Callback<CreatedOrUpdated<TModel>>();
		onAfterUpdated = new Subject<TModel>();
		@Inject(repository) repo: typeof repository;
		@Inject(EventsService) eventsService: EventsService;

		async onModuleInit() {}

		async findOne(id: string | number | FindOptions) {
			return (
				await this.list(
					typeof id == 'object'
						? id
						: {
								where: {
									id: id as any,
								},
						  }
				)
			).data[0];
		}

		async list(params: FindOptions) {
			const scopes = [
				this.repo.scopes.find ? this.repo.scopes.find() : null,
			].filter((i) => !!i);
			const data = await this.repo
				.scope(scopes as any)
				.findAndCountAll(parseFindParams(params));

			return {
				data: data.rows,
				metadata: {
					count: data.count,
				},
			};
		}

		async getUserIds(id: string | number, scope = 'find') {
			if (repository.accessors.canFind) {
				const query = await repository.accessors.canFind(id);
				const ids = query.map((i: any) => i.id) as string[];
				return ids;
			}
			return [];
		}

		async update(id, params) {
			const scopes = [
				repository.scopes.edit ? repository.scopes.edit() : null,
				repository.scopes.find ? repository.scopes.find() : null,
			].filter((i) => !!i);
			const record = await this.repo.scope(scopes as any).findByPk(id);
			const entity = await record.set(params).save();

			await this.afterUpdate.execute({ entity, params });
			await this.onAfterUpdated.next(entity);

			await this.eventsService.trigger(
				new TriggeredEvent(
					new Event(
						this.repo.name.toLowerCase() + '.updated',
						entity
					),
					await this.getUserIds(entity.id)
				)
			);

			return entity;
		}

		async create(params) {
			await this.beforeCreate.execute(params);
			const entity = await this.repo.create(params);

			await this.afterCreate.execute({ entity, params });
			await this.onAfterCreated.next(entity);

			await this.eventsService.trigger(
				new TriggeredEvent(
					new Event(
						this.repo.name.toLowerCase() + '.created',
						entity
					),
					await this.getUserIds(entity.id)
				)
			);

			return entity;
		}

		async createOrUpdate(params) {
			try {
				return await this.create(params);
			} catch (e) {
				if (e instanceof UniqueConstraintError) {
					const element = await this.findWithUniqueKeys(params);
					return this.update(element.id, params);
				}
				throw e;
			}
		}

		async findWithUniqueKeys(params) {
			const uniqueKeys = Object.values(this.repo.getAttributes())
				.filter((i) => i.unique)
				.map((key) => ({
					[key.field]: params[key.field],
				}))
				.reduce(
					(prev, curr) => ({
						...prev,
						...curr,
					}),
					{}
				);

			return this.findOne({
				where: uniqueKeys,
			});
		}
	}

	return X;
};

const parseFindParams = (params) => {
	if (!params) return null;
	Object.keys(params).forEach((key) => {
		if (['lt', 'gt', 'eq', 'like'].includes(key)) {
			params[Op[key]] = params[key];
			delete params[key];
			key = Op[key];
		}
		if (typeof params[key] === 'object') {
			params[key] = parseFindParams(params[key]);
		}
	});
	return params;
};
