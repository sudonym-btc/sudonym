import { Body, Get, Inject, Param, Post, Put, Query } from '@nestjs/common';
import { Constructor } from 'sequelize-typescript/dist/shared/types';
import { ParseRequest } from 'helper/parse-request.decorator';
import { TBaseService, TControllerAndService } from './base.service';
import { requestContextCls } from 'helper/context-request';

export interface TBaseController<TService, TModel>
	extends TControllerAndService<TModel> {
	service: TService;
}

export interface BaseControllerOptions<TModel> {
	model?: TModel;
}

export const BaseController = <TService extends TBaseService<TModel>, TModel>(
	service: Constructor<TService>,
	model: Constructor<TModel>
): Constructor<TBaseController<TService, TModel>> => {
	class X {
		@Inject(service) service: TService;

		async onModuleInit() {}

		@Get(':id')
		findOne(@Param('id') id: string | number, @ParseRequest() req) {
			return this.service.findOne(id, req);
		}

		@Get('')
		list(@Query() params, @ParseRequest() req) {
			return this.service.list(params, req);
		}

		@Post('')
		create(@Body() data, @ParseRequest() req) {
			return this.service.create(data, req);
		}

		@Put(':id')
		update(@Param('id') id, @Body() data, @ParseRequest() req) {
			return this.service.update(id, data, req);
		}
	}
	return X;
};
