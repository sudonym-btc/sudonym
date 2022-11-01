import { Body, CanActivate, Get, Inject, Param, Post, Put, Query, UseGuards } from '@nestjs/common';
import { Constructor } from 'sequelize-typescript/dist/shared/types';
import { TBaseService, TControllerAndService } from './base.service';

export interface TBaseController<TService, TModel>
	extends TControllerAndService<TModel> {
	service: TService;
}

export interface BaseControllerOptions<TModel> {
	model?: TModel;
}

export const BaseController = <TService extends TBaseService<TModel>, TModel>(options: {
	service: Constructor<TService>,
	model: Constructor<TModel>,
	create?: {
		guards?: CanActivate[],
		update: true
	},
	update?: {
		guards?: CanActivate[]
	},
	list?: {
		guards?: CanActivate[]
	},
	get?: {
		guards?: CanActivate[]
	}
}): Constructor<TBaseController<TService, TModel>> => {
	class X {
		@Inject(options.service) service: TService;

		async onModuleInit() {}

		@UseGuards(...options.get?.guards)
		@Get(':id')
		findOne(@Param('id') id: string | number) {
			return this.service.findOne(id);
		}

		@UseGuards(...options.list?.guards)
		@Get('')
		list(@Query() params) {
			return this.service.list(params);
		}

		@UseGuards(...options.create?.guards)
		@Post('')
		create(@Body() data) {
			if(options.create?.update) {
				return this.service.createOrUpdate(data);
			}
			return this.service.create(data);
		}

		@UseGuards(...options.update?.guards)
		@Put(':id')
		update(@Param('id') id, @Body() data) {
			return this.service.update(id, data);
		}
	}
	return X;
};
