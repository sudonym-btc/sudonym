import { Sequelize } from 'sequelize-typescript'
import { getConfig } from '../config/config';
import { User } from '../module/user/user.model';

export const sequelize = new Sequelize({
  ...getConfig().database,
  models: [
      User
  ]
});