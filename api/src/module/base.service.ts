import { Inject } from '@nestjs/common';
import {
	Constructor,
	RecursivePartial,
} from 'sequelize-typescript/dist/shared/types';
import { EventsService } from './events/events.service';
import { Event } from '@sudonym/models';
import { Callback } from '../helper/callback';
import { FindOptions, Op } from 'sequelize';
import { RequestType } from 'helper/parse-request.decorator';
import { BaseModel } from './base.model';
import { Subject } from 'rxjs';

type ModelType<T> = Constructor<T> & typeof BaseModel;

export interface TControllerAndService<TModel> {
	findOne(id, req?: RequestType): Promise<TModel>;
	create(
		params: RecursivePartial<TModel>,
		req?: RequestType
	): Promise<TModel>;
	update(
		id,
		params: RecursivePartial<TModel>,
		req?: RequestType
	): Promise<TModel>;
	list(
		param: FindOptions,
		req?: RequestType
	): Promise<{
		data: TModel[];
		metadata: {
			count: number;
		};
	}>;
}
export interface TBaseService<TModel> extends TControllerAndService<TModel> {
	afterCreate: Callback<TModel>;
	onAfterCreated: Subject<TModel>;
	afterUpdate: Callback<TModel>;
	onAfterUpdated: Subject<TModel>;
}

export const BaseService = <TModel extends BaseModel>(
	repository: ModelType<TModel>
): Constructor<TBaseService<TModel>> => {
	class X {
		afterCreate = new Callback<TModel>();
		onAfterCreated = new Subject<TModel>();
		afterUpdate = new Callback<TModel>();
		onAfterUpdated = new Subject<TModel>();
		@Inject(repository) repo: typeof repository;
		@Inject(EventsService) eventsService: EventsService;

		async findOne(id: string | number, req: RequestType) {
			return (
				await this.list(
					{
						where: {
							id: id as any,
						},
					},
					req
				)
			).data[0];
		}

		async list(params: FindOptions, req: RequestType) {
			const scopes = [
				this.repo.scopes.find ? this.repo.scopes.find(req) : null,
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

		async update(id, params, req: RequestType) {
			const scopes = [
				repository.scopes.edit ? repository.scopes.edit(req) : null,
				repository.scopes.find ? repository.scopes.find(req) : null,
			].filter((i) => !!i);
			const record = await this.repo.scope(scopes as any).findByPk(id);
			const obj = await record.set(params).save();

			await this.eventsService.trigger(
				new Event(this.repo.name.toLowerCase() + '.updated', obj)
			);

			await this.afterUpdate.execute(obj);
			await this.onAfterUpdated.next(obj);
			return obj;
		}

		async create(params, req: RequestType) {
			const obj = await this.repo.create(params);
			await this.eventsService.trigger(
				new Event(this.repo.name.toLowerCase() + '.created', obj)
			);

			await this.afterCreate.execute(obj);
			await this.onAfterCreated.next(obj);
			return obj;
		}
	}

	return X;
};

const parseFindParams = (params) => {
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
