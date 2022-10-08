import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { Contact } from './contact.model';
import { ContactService } from './contact.service';

@Controller('contact')
export class ContactController extends BaseController(
	ContactService,
	Contact
) {}
