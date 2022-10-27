import { BadRequestException, INestApplication, Logger, ValidationPipe } from "@nestjs/common";
import { ValidationError } from "class-validator";
import { contextRequest } from "helper/context-request";
import { requestLogger } from "helper/logger";
import { AuthService } from "module/auth/auth.service";
import { WsAdapter } from "module/events/websocket-adapter";
const logger = new Logger('Global');

export const applyGlobals = (app: INestApplication) => {

    logger.log("Applying global validators and interceptors");
    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true, transform: true, exceptionFactory: (validationErrors: ValidationError[] = []) => {
                return new BadRequestException(validationErrors);
            },
        })
    );
    app.useWebSocketAdapter(new WsAdapter(app));
    app.use(requestLogger);
    app.use(contextRequest(app.get(AuthService)));
}