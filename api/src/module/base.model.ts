import { Model } from "sequelize-typescript";
import { FindOptions } from "sequelize/types";
import { RequestType } from "src/helper/parse-request.decorator";

export class BaseModel extends Model {
    static scopes: {
        [key: string]: (req: RequestType) => FindOptions
    } = {};
}