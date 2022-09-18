import { Inject, Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { Contact } from './contact.model';

@Injectable()
export class ContactService extends BaseService(Contact) {}
