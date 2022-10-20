import { Inject, Injectable, Logger } from '@nestjs/common';
import { ContactAddress } from 'module/contact-address/contact-address.model';
import { ContactAddressService } from 'module/contact-address/contact-address.service';
import { ContactService } from 'module/contact/contact.service';
import { PotUser } from 'module/pot-user/pot-user.model';
import { TransactionService } from 'module/transaction/transaction.service';
import { UserService } from 'module/user/user.service';
import { Op } from 'sequelize';

@Injectable()
export class TransactionContactLinkerService {
	private readonly logger = new Logger(this.constructor.name);

	@Inject() contactService: ContactService;
	@Inject() transactionService: TransactionService;
	@Inject() contactAddressService: ContactAddressService;

	onModuleInit() {
		this.transactionService.beforeCreate.hook(async params => {
			params.contactAddressId = (await this.contactAddressService.findOne({
				where: {
					address: params.originalAddress
				}
			}))?.id;
		});

		const transactionSearcher = async ({entity}) => {
			const contact = await this.contactService.findOne(entity.contactId);

			const transactions = await this.transactionService.list({
				where: {
					originalAddress: entity.address,
					potId: {
						[Op.in]: (await PotUser.findAll({
							attributes: ['potId'],
							where: {
								userId: contact.userId
							}
						})).map(i => i.potId)
					}
				}
			});

			for (const transaction of transactions.data) {
				if (transaction.contactAddressId == null) {
					await this.transactionService.update(transaction.id, {
						contactAddressId: entity.id
					})
				}
			}
		}

		this.contactAddressService.afterCreate.hook(transactionSearcher);
		this.contactAddressService.afterUpdate.hook(transactionSearcher);
	}
}