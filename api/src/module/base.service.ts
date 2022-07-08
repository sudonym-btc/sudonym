import { Inject } from "@nestjs/common";
import { Constructor, RecursivePartial } from "sequelize-typescript/dist/shared/types";
import { EventsService } from "./events/events.service";
import { Event } from "@sudonym/models";
import { Callback } from "../helper/callback";
import { FindOptions, Op } from "sequelize";
import { RequestType } from "src/helper/parse-request.decorator";
import { BaseModel } from "./base.model";

type ModelType<T> = Constructor<T> & typeof BaseModel;

export interface TControllerAndService<TModel> {
    findOne(id, req?: RequestType): Promise<TModel>;
    create(params: RecursivePartial<TModel>, req?: RequestType);
    update(id, params: RecursivePartial<TModel>, req?: RequestType);
    list(param: FindOptions, req?: RequestType): Promise<{
        data: TModel[],
        metadata: {
            count: number
        }
    }>;
}
export interface TBaseService<TModel> extends TControllerAndService<TModel> {
    onAfterCreated: Callback<TModel>;
    onAfterUpdated: Callback<TModel>;
}

export const BaseService = <TModel extends BaseModel>(repository: ModelType<TModel>): Constructor<TBaseService<TModel>> => {

    class X {
        onAfterCreated = new Callback<TModel>();
        onAfterUpdated = new Callback<TModel>();
        @Inject(repository) repo: typeof repository;
        @Inject(EventsService) eventsService: EventsService;

        async findOne(id: string | number, req: RequestType) {
            return (await this.list({
                where: {
                    id: id as any
                }
            }, req)).data[0];
        }

        async list(params: FindOptions, req: RequestType) {
            const scopes = [
                this.repo.scopes.find ? this.repo.scopes.find(req) : null
            ].filter(i => !!i);
            const data = await this.repo.scope(scopes as any).findAndCountAll(parseFindParams(params));
            return {
                data: data.rows,
                metadata: {
                    count: data.count
                }
            };
        }

        async update(id, params, req: RequestType) {
            const obj = await this.repo.sequelize.transaction(async t => {

                const scopes = [
                    repository.scopes.edit ? repository.scopes.edit(req) : null,
                    repository.scopes.find ? repository.scopes.find(req) : null,
                ].filter(i => !!i);

                const record = await this.repo.scope(scopes as any).findByPk(id);

                const obj = await record.set(params).save();

                await this.eventsService.trigger(new Event(this.repo.name + ".updated", obj));

                return obj;
            });
            await this.onAfterUpdated.execute(obj);
            return obj;
        }

        async create(params, req: RequestType) {
            const obj = await this.repo.sequelize.transaction(async t => {

                const obj = await this.repo.create(params);
                await this.eventsService.trigger(new Event(this.repo.name + ".created", obj));

                return obj;
            });
            await this.onAfterCreated.execute(obj);
            return obj;
        }
    }

    return X;
}

const parseFindParams = (params) => {
    Object.keys(params).forEach(key => {
        if (['lt', 'gt', 'eq'].includes(key)) {
            params[Op[key]] = params[key];
            delete params[key];
            key = Op[key];
        }
        if (typeof params[key] === 'object') {
            params[key] = parseFindParams(params[key]);
        }
    })
    return params;
}