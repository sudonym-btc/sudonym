import { Inject, Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { ContactAddress } from './contact-address.model';

@Injectable()
export class ContactAddressService extends BaseService(ContactAddress) {}
