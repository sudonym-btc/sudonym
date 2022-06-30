import { Body, Get, Inject, Param, Post, Put } from "@nestjs/common";
import { Constructor } from "sequelize-typescript/dist/shared/types";
import { TBaseService, TControllerAndService } from "./base.service";

export interface TBaseController<TService, TModel> extends TControllerAndService<TModel> {
    service: TService;
}

export interface BaseControllerOptions<TModel> {
    model?: TModel;
}

export const BaseController = <TService extends TBaseService<TModel>, TModel>(
    service: Constructor<TService>,
    model: Constructor<TModel>
):
    Constructor<TBaseController<TService, TModel>> => {

    class X {
        @Inject(service) service: TService;

        @Get(':id')
        findOne(@Param('id') id: string | number) {
            return this.service.findOne(id);
        }

        @Get('')
        list() {
            return this.service.list();
        }

        @Post('')
        create(@Body() data) {
            return this.service.create(data);
        }

        @Put(':id')
        update(@Param('id') id, @Body() data) {
            return this.service.update(id, data);
        }
    };
    return X;
}