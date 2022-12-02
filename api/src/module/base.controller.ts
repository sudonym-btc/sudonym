import {
	BadRequestException,
	Body,
	CanActivate,
	Delete,
	Get,
	Inject,
	Logger,
	Param,
	Post,
	Put,
	Query,
	UseGuards,
	UsePipes,
	ValidationError,
	ValidationPipe,
} from '@nestjs/common';
import { conditional } from 'conditional-decorator';
import { AuthGuard } from 'helper/auth.guard';
import { Constructor } from 'sequelize-typescript/dist/shared/types';
import { TBaseService, TControllerAndService } from './base.service';

export interface TBaseController<TService, TModel>
	extends TControllerAndService<TModel> {
	service: TService;
}

export interface BaseControllerOptions<
	TService extends TBaseService<TModel>,
	TModel,
	TCreate,
	TUpdate
> {
	service: Constructor<TService>;
	model?: Constructor<TModel>;
	auth?: boolean;
	create?:
		| false
		| Partial<
				EndpointOptions<Constructor<TCreate>, TModel> & {
					update: true;
				}
		  >;
	delete?: false | Partial<EndpointOptions<Constructor<TUpdate>, TModel>>;
	update?: false | Partial<EndpointOptions<Constructor<TUpdate>, TModel>>;
	list?: false | Partial<EndpointOptions<TModel, TModel>>;
	get?: false | Partial<EndpointOptions<TModel, TModel>>;
}
interface EndpointOptions<TIn, TOut> {
	input: TIn;
	model: TOut;
	validator: {
		whitelist: boolean;
	};
	auth: boolean;
	guards: CanActivate[];
}

export const BaseController = <
	TService extends TBaseService<TModel>,
	TModel,
	TCreate,
	TUpdate
>(
	options: BaseControllerOptions<TService, TModel, TCreate, TUpdate>
): Constructor<TBaseController<TService, TModel>> => {
	const logger = new Logger(options.service.name);
	const defaultOptions: Partial<
		BaseControllerOptions<TService, TModel, TCreate, TUpdate>
	> = {
		auth: true,
	};
	options = Object.assign(defaultOptions, options);
	const defaultEndpointOptions: Partial<EndpointOptions<TModel, TModel>> = {
		auth: options.auth,
	};
	['get', 'list', 'update', 'create', 'delete'].forEach((i) => {
		options[i] = Object.assign(
			Object.assign({}, defaultEndpointOptions),
			options[i] || {}
		);
	});

	const exceptionFactory = (validationErrors: ValidationError[] = []) => {
		logger.log(validationErrors);
		return new BadRequestException(validationErrors);
	};

	const getGuards = (obj) =>
		[...(obj.guards || []), obj.auth ? AuthGuard : null].filter((i) => !!i);
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
		@UsePipes(
			new ValidationPipe({
				whitelist: true,
				transform: true,
				expectedType: options.create && options.create.input,
				...(options.create ? options.create.validator : {}),
				exceptionFactory,
				skipUndefinedProperties: true, // todo: why are updates coming through undefined
			})
		)
		@conditional(!!options.create, Post(''))
		create(@Body() data: TCreate) {
			if (options.create && options.create?.update) {
				return this.service.createOrUpdate(data);
			}
			return this.service.create(data);
		}

		@UseGuards(...getGuards(options.update))
		@UsePipes(
			new ValidationPipe({
				whitelist: true,
				transform: true,
				expectedType: options.update && options.update.input,
				...(options.update ? options.update.validator : {}),
				exceptionFactory,
				skipUndefinedProperties: true, // todo: why are updates coming through undefined
			})
		)
		@conditional(!!options.update, Put(':id'))
		update(@Param('id') id, @Body() data: TUpdate) {
			return this.service.update(id, data);
		}

		@UseGuards(...getGuards(options.delete))
		@Delete(':id')
		delete(@Param('id') id) {
			return this.service.delete(id);
		}
	}
	return X;
};
