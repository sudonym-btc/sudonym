'use strict';
const { DataTypes } = require('sequelize');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
	async up(queryInterface, Sequelize) {
		// Add column to receiver
		// Add foreign relation to transaction
		//

		return queryInterface
			.removeColumn('Transactions', 'billSplitId')
			.then(() =>
				queryInterface.addColumn('Transactions', 'billSplitId', {
					type: DataTypes.INTEGER,
					allowNull: true,
					references: {
						model: 'BillSplits', // name of Target model
						key: 'id', // key in Target model that we're referencing
					},
				})
			)
			.then(() =>
				queryInterface.removeColumn(
					'Receivers',
					'billSplitParticipantId'
				)
			)
			.then(() =>
				queryInterface.addColumn(
					'Receivers',
					'billSplitParticipantId',
					{
						type: DataTypes.INTEGER,
						allowNull: true,
						references: {
							model: 'BillSplitParticipants', // name of Target model
							key: 'id', // key in Target model that we're referencing
						},
					}
				)
			);
	},

	async down(queryInterface, Sequelize) {},
};
