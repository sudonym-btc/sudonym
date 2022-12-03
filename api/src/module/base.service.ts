import { Inject, NotFoundException } from '@nestjs/common';
import { Event } from '@sudonym/models';
import { sequelizeCls } from 'database/database.providers';
import { runAsUser } from 'helper/context-request';
import { FindOptions, Op, UniqueConstraintError } from 'sequelize';
import {
	Constructor,
	RecursivePartial,
} from 'sequelize-typescript/dist/shared/types';
import { Callback } from '../helper/callback';
import { BaseModel } from './base.model';
import { EventsService, TriggeredEvent } from './events/events.service';

type ModelType<T> = Constructor<T> & typeof BaseModel;

export interface TControllerAndService<TModel> {
	onModuleInit(): any;
	findOne(id): Promise<TModel>;
	create(params: RecursivePartial<TModel>): Promise<TModel>;
	update(id, params: RecursivePartial<TModel>): Promise<TModel>;
	delete(id): Promise<TModel>;
	list(
		param?: FindOptions,
		options?
	): Promise<{
		data: TModel[];
		metadata: {
			count: number;
		};
	}>;
}
export interface TBaseService<TModel> extends TControllerAndService<TModel> {
	beforeCreate: Callback<TModel>;
	afterCreate: Callback<CreatedOrUpdated<TModel>>;
	onAfterCreated: Callback<TModel>;
	beforeUpdate: Callback<CreatedOrUpdated<TModel>>;
	afterUpdate: Callback<CreatedOrUpdated<TModel>>;
	onAfterUpdated: Callback<TModel>;
	beforeDelete: Callback<TModel>;
	afterDelete: Callback<CreatedOrUpdated<TModel>>;
	onAfterDeleted: Callback<TModel>;
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
		onAfterCreated = new Callback<TModel>();
		beforeUpdate = new Callback<CreatedOrUpdated<TModel>>();
		afterUpdate = new Callback<CreatedOrUpdated<TModel>>();
		onAfterUpdated = new Callback<TModel>();
		beforeDelete = new Callback<TModel>();
		afterDelete = new Callback<CreatedOrUpdated<TModel>>();
		onAfterDeleted = new Callback<TModel>();
		@Inject(repository) repo: typeof repository;
		@Inject(EventsService) eventsService: EventsService;

		async onModuleInit() {}

		async findOne(id: string | number | FindOptions) {
			const obj = (
				await this.list(
					typeof id == 'object'
						? id
						: {
								where: {
									id: id as any,
								},
						  },
					{
						scopes: [
							repository.scopes.findOne
								? repository.scopes.findOne()
								: null,
						],
					}
				)
			).data[0];
			if (!obj) {
				throw new NotFoundException();
			}
			return obj;
		}

		async list(params: FindOptions, options: ListOptions = { scopes: [] }) {
			params = parseParams(params);
			const scopes = [
				...(options.scopes || []),
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
				const users = await repository.accessors.canFind(id);
				const ids = users.map((i: any) => i.id) as string[];
				return ids;
			}
			return [];
		}

		newTransaction(cb) {
			sequelizeCls.run(async () => {
				sequelizeCls.set('transaction', undefined);
				await cb();
			});
		}

		async triggerEventForUsers(userIds, event, entity) {
			// For each user fetch as correct scope
			for (const user of userIds) {
				await runAsUser({ id: user }, async () => {
					const e = await this.findOne(entity.id);
					await this.eventsService.trigger(
						new TriggeredEvent(
							new Event(
								this.repo.name.toLowerCase() + '.' + event,
								e
							),
							[user]
						)
					);
				});
			}
		}

		async update(id, params) {
			return await this.repo.sequelize.transaction(
				{ transaction: sequelizeCls.get('transaction') },
				async (t) => {
					const scopes = [
						repository.scopes.edit
							? repository.scopes.edit()
							: null,
						repository.scopes.find
							? repository.scopes.find()
							: null,
					].filter((i) => !!i);
					const record = await this.repo
						.scope(scopes as any)
						.findByPk(id);
					await this.beforeUpdate.execute({ params, entity: record });

					const _previousDataValues = Object.assign(
						{},
						(record as any)._previousDataValues
					);
					const changed = record.set(params).changed();
					await record.save();
					const entity = await this.findOne(record.id);
					if (changed) (entity as any)._changed = new Set(changed);
					(entity as any)._previousDataValues = _previousDataValues;

					await this.afterUpdate.execute({ entity, params });

					t.afterCommit(() => {
						this.newTransaction(async () => {
							this.onAfterUpdated.execute(entity);

							const users = await this.getUserIds(entity.id);
							this.triggerEventForUsers(users, 'updated', entity);
						});
					});

					return entity;
				}
			);
		}

		async create(params) {
			return await this.repo.sequelize.transaction(
				{ transaction: sequelizeCls.get('transaction') },
				async (t) => {
					await this.beforeCreate.execute(params);
					const newEntity = await this.repo.create(params);
					const entity = await this.findOne(newEntity.id);
					entity.isNewRecord = true;

					await this.afterCreate.execute({ entity, params });

					t.afterCommit(async () => {
						this.newTransaction(async () => {
							this.onAfterCreated.execute(entity);
							this.triggerEventForUsers(
								await this.getUserIds(entity.id),
								'created',
								entity
							);
						});
					});

					return entity;
				}
			);
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

		async delete(id: number | string) {
			return await this.repo.sequelize.transaction(
				{ transaction: sequelizeCls.get('transaction') },
				async (t) => {
					const entity = await this.findOne(id);
					await this.beforeDelete.execute(entity);
					const userIds = await this.getUserIds(entity.id);

					await entity.destroy();

					await this.afterDelete.execute({ entity, params: entity });

					t.afterCommit(async () => {
						this.newTransaction(async () => {
							this.onAfterDeleted.execute(entity);
							this.eventsService.trigger(
								new TriggeredEvent(
									new Event(
										this.repo.name.toLowerCase() +
											'.deleted',
										entity
									),
									userIds
								)
							);
						});
					});

					return entity;
				}
			);
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

class ListOptions {
	scopes;
}

const parseParams = (params) => {
	if (typeof params == 'object') {
		if (!params) return params;
		if (Array.isArray(params)) {
			return params.map(parseParams);
		}
		return Reflect.ownKeys(params).reduce(
			(acc, i) => ({
				...acc,
				[typeof i == 'string'
					? i.includes('.')
						? i // '$' + i + '$' could add this but currently adding on frontend
						: i
					: i]: parseParams(params[i]),
			}),
			{}
		);
	}
	return params;
};
