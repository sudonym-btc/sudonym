import { Body, CanActivate, Get, Inject, Param, Post, Put, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from 'helper/auth.guard';
import { Constructor, RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { TBaseService, TControllerAndService } from './base.service';

export interface TBaseController<TService, TModel>
	extends TControllerAndService<TModel> {
	service: TService;
}

export interface BaseControllerOptions<TService extends TBaseService<TModel>, TModel> {
	service: Constructor<TService>
	model?: Constructor<TModel>;
	auth?: boolean
	create?:  Partial<EndpointOptions & {
		update: true
	}>;
	update?: Partial<EndpointOptions>
	list?:  Partial<EndpointOptions>
	get?:  Partial<EndpointOptions>
}
interface EndpointOptions {
	model: any;
	auth: boolean;
	guards: CanActivate[];
}

export const BaseController = <TService extends TBaseService<TModel>, TModel>(options: BaseControllerOptions<TService, TModel>): Constructor<TBaseController<TService, TModel>> => {
	const defaultOptions: Partial<BaseControllerOptions<TService, TModel>> = {
		auth: true
	}
	options = Object.assign(defaultOptions, options);
	const defaultEndpointOptions: Partial<EndpointOptions> = {
		auth: options.auth
	};
	['get', 'list', 'update', 'create'].forEach(i => {
		options[i] = Object.assign(defaultEndpointOptions, options[i] || {})
	})

	console.log(options, AuthGuard);
	const getGuards = obj => [...(obj.guards || []), obj.auth ? AuthGuard : null].filter(i => !!i)
	class X {
		@Inject(options.service) service: TService;

		async onModuleInit() {}

		@UseGuards(...getGuards(options.get))
		@Get(':id')
		findOne(@Param('id') id: string | number) {
			return this.service.findOne(id);
		}

		@UseGuards(...getGuards(options.list))
		@Get('')
		list(@Query() params) {
			return this.service.list(params);
		}

		@UseGuards(...getGuards(options.create))
		@Post('')
		create(@Body() data) {
			if(options.create?.update) {
				return this.service.createOrUpdate(data);
			}
			return this.service.create(data);
		}

		@UseGuards(...getGuards(options.update))
		@Put(':id')
		update(@Param('id') id, @Body() data) {
			return this.service.update(id, data);
		}
	}
	return X;
};
