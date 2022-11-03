import {
	Injectable,
	NestInterceptor,
	ExecutionContext,
	BadGatewayException,
	CallHandler,
	BadRequestException,
} from '@nestjs/common';
import { ValidationError } from 'class-validator';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Injectable()
export class ValidationErrorInterceptor implements NestInterceptor {
	intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
		return next.handle().pipe(
			catchError((err) => {
				if (err instanceof ValidationError || err.errors) {
					err.errors.map((e) => {
						e.property = e.path;
						return e;
					});
					console.log(JSON.parse(JSON.stringify(err.errors)));
					return throwError(
						() =>
							new BadRequestException({
								message: JSON.parse(JSON.stringify(err.errors)),
							})
					);
				}
				console.log('nont ');
				return throwError(() => err);
			})
		);
	}
}
