import { TransactionService } from 'module/transaction/transaction.service';
import { scaffoldGroup } from './mock/scaffold-group';
import { ContactService } from 'module/contact/contact.service';

scaffoldGroup('Payment Contacts', (scaffold) => {
    it('should allocate contactAddress id to transaction if recognized', async () => {
        const contact = await scaffold.app.get(ContactService).create({
            userId: scaffold.entities.user[0].id,
            name: 'testing',
            ContactAddresses: [{
                address: 'lnurl123'
            }]
        })
        const transaction = await scaffold.app.get(TransactionService).create({
            outgoing: true,
            potId: scaffold.entities.pot[0].id,
            type: 'bolt11',
            currencyCode: 'BTC',
            originalAddress: 'lnurl123',
            address: 'lnurl123',
            amount: 1,
        });

        expect(transaction.contactAddressId).toBe(contact.ContactAddresses[0].id);
    });

    it('should assign transaction contact address id on contact create', async () => {
        let transaction = await scaffold.app.get(TransactionService).create({
            outgoing: true,
            potId: scaffold.entities.pot[0].id,
            type: 'bolt11',
            currencyCode: 'BTC',
            originalAddress: 'lnurl123',
            address: 'lnurl123',
            amount: 1,
        });
        const contact = await scaffold.app.get(ContactService).create({
            userId: scaffold.entities.user[0].id,
            name: 'testing',
            ContactAddresses: [{
                address: 'lnurl123'
            }]
        })

        transaction = await scaffold.app.get(TransactionService).findOne(transaction.id);

        expect(transaction.contactAddressId).toBe(contact.ContactAddresses[0].id);

    })

});
