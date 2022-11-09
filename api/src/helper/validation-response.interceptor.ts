import {
	BadRequestException,
	CallHandler,
	ExecutionContext,
	Injectable,
	NestInterceptor
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
					return throwError(
						() =>
							new BadRequestException({
								message: JSON.parse(JSON.stringify(err.errors)),
							})
					);
				}
				console.log(err);
				return throwError(() => err);
			})
		);
	}
}
