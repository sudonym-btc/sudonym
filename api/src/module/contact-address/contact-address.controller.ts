import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { ContactAddress } from './contact-address.model';
import { ContactAddressService } from './contact-address.service';

@Controller('contact-address')
export class ContactAddressController extends BaseController({
	service: ContactAddressService,
	model: ContactAddress,
}) {}
