import { Inject, Injectable } from '@nestjs/common';
import { PotService } from 'src/module/pot/pot.service';
import { TransactionService } from 'src/module/transaction/transaction.service';

@Injectable()
export class BalanceUpdaterService {
    @Inject(PotService) potService: PotService;
    @Inject(TransactionService) transactionService: TransactionService;

    onModuleInit() {
        this.transactionService.onAfterCreated.hook(async (t) => {
            const pot = await this.potService.findOne(t.potId);
            let newBalance = pot.balance;
            let newSpendableBalance = pot.spendableBalance;

            if (t.outgoing) {
                newBalance -= t.amount;
                newSpendableBalance -= t.amount;
            } else {
                newBalance += t.amount;
                if (t.status == true) {
                    newSpendableBalance += t.amount;
                }
            }

            await this.potService.update(pot.id, {
                balance: newBalance,
                spendableBalance: newSpendableBalance
            });
        });

        this.transactionService.onAfterUpdated.hook(async (t) => {
            const pot = await this.potService.findOne(t.potId);

            let newBalance = pot.balance;
            let newSpendableBalance = pot.spendableBalance;

            if (t.changed('status')) {

                // Increase spendable balance when outgoing fails
                if (t.outgoing) {
                    if (t.status == false)
                        newSpendableBalance += t.amount;
                } else {
                    if(t.status == true) {
                        newSpendableBalance += t.amount;
                    } else {
                        newBalance -= t.amount;
                    }
                }

                await this.potService.update(pot.id, {
                    balance: newBalance,
                    spendableBalance: newSpendableBalance
                });
            }

        })
    }
}