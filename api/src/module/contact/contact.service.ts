import { Inject, Injectable } from '@nestjs/common';
import { ContactAddress } from 'module/contact-address/contact-address.model';
import { ContactAddressService } from 'module/contact-address/contact-address.service';
import { Op } from 'sequelize';
import { BaseService } from '../base.service';
import { Contact } from './contact.model';

@Injectable()
export class ContactService extends BaseService(Contact) {
	@Inject(ContactAddressService) contactAddressService: ContactAddressService;

	onModuleInit() {
		const hook = async ({ params, entity }) => {
			await this.contactAddressService.list({
				where: {
					contactId: entity.id,
					id: {
						[Op.notIn]: params.ContactAddresses.map((i) => i.id),
					},
				},
			});

			await ContactAddress.destroy({
				where: {
					contactId: entity.id,
					id: {
						[Op.notIn]: params.ContactAddresses.map((i) => i.id),
					},
				},
			});

			params.ContactAddresses = entity.ContactAddresses =
				await Promise.all(
					params.ContactAddresses.map((a) =>
						this.contactAddressService
							.createOrUpdate({
								...a,
								contactId: entity.id,
							})
							.then((e) => e.entity)
					)
				);
		};

		this.afterUpdate.hook(hook);
		this.afterCreate.hook(hook);
	}
}
