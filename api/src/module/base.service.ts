import { Inject } from "@nestjs/common";
import { Model } from 'sequelize-typescript';
import { Constructor, RecursivePartial } from "sequelize-typescript/dist/shared/types";
import { EventsService } from "./events/events.service";
import { Event } from "@sudonym/models";
import { Callback } from "src/helper/callback";
import { FindOptions, WhereOptions } from "sequelize/types";

type ModelType<T> = Constructor<T> & typeof Model;

export interface TControllerAndService<TModel> {
    findOne(id): Promise<TModel>;
    create(params: RecursivePartial<TModel>);
    update(id, params: RecursivePartial<TModel>);
    list();
}
export interface TBaseService<TModel> extends TControllerAndService<TModel> {
    find(FindOptions);
    onAfterCreated: Callback<TModel>;
    onAfterUpdated: Callback<TModel>;
}

export const BaseService = <TModel extends Model>(repository: ModelType<TModel>): Constructor<TBaseService<TModel>> => {

    class X {
        onAfterCreated = new Callback<TModel>();
        onAfterUpdated = new Callback<TModel>();
        @Inject(repository) repo: typeof repository;
        @Inject(EventsService) eventsService: EventsService;

        async findOne(id: string | number) {
            return (await this.repo.findOne({
                where: {
                    id: id as any
                }
            }));
        }

        async find(opts: FindOptions) {
            return (await this.repo.findOne(opts));
        }

        async update(id, params) {
            const obj = await this.repo.sequelize.transaction(async t => {

                const record = await this.repo.findByPk(id);

                const obj = await record.set(params).save();

                await this.eventsService.trigger(new Event(this.repo.name + ".updated", obj));

                return obj;
            });
            await this.onAfterUpdated.execute(obj);
            return obj;
        }

        async create(params) {
            const obj = await this.repo.sequelize.transaction(async t => {

                const obj = await this.repo.create(params);
                await this.eventsService.trigger(new Event(this.repo.name + ".created", obj));

                return obj;
            });
            await this.onAfterCreated.execute(obj);
            return obj;
        }

        list() {
            return this.repo.findAll();
        }
    }

    return X;
}