import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { LightningModule } from './lightning/lightning.module';
import { AuthModule } from './module/auth/auth.module';
import { PotModule } from './module/pot/pot.module';
import { UserModule } from './module/user/user.module';

@Module({
  imports: [
    DatabaseModule,
    LightningModule,
    AuthModule, 
    UserModule,
    PotModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }