import { Inject } from "@nestjs/common";
import { Model} from 'sequelize-typescript';
import { Constructor } from "sequelize-typescript/dist/shared/types";

type ModelType<T> = Constructor<T> & typeof Model;

export interface TControllerAndService<TModel> {
    findOne(id): Promise<TModel>;
    create(params);
    list();
}
export interface TBaseService<TModel> extends TControllerAndService<TModel> {
    // repo: typeof TModel;
}

export const BaseService = <TModel extends Model>(repository: ModelType<TModel>): Constructor<TBaseService<TModel>> => {

    class X {
        @Inject(repository) repo: typeof repository;

        async findOne(id: string | number) {
            return (await this.repo.findOne({
                where: {
                    id
                }
            }));
        }

        create(params) {
            return this.repo.create(params);
        }

        list() {
            return this.repo.findAll();
        }
    }

    return X;
}