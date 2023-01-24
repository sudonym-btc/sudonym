'use strict';
const { DataTypes } = require('sequelize');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
	async up(queryInterface, Sequelize) {
		// Add column to receiver
		// Add foreign relation to transaction
		//

		return queryInterface.removeColumn('Pots', 'roundup').then(() =>
			queryInterface.addColumn('Pots', 'roundup', {
				type: DataTypes.BOOLEAN,
				allowNull: false,
				defaultValue: false,
			})
		);
	},

	async down(queryInterface, Sequelize) {},
};
