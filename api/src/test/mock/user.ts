import { hash } from "../../module/auth/auth.service";
import { User } from "../../module/user/user.model";

export const USER_PASSWORD = 'random long password';
export const USER_PASSWORD_HASH = hash(USER_PASSWORD);

export const createUsers = () => {
    return User.bulkCreate([
        {
            id: 1
        }
    ])
}