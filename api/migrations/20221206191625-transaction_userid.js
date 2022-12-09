'use strict';
const { DataTypes } = require('sequelize');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
	async up(queryInterface, Sequelize) {
		return queryInterface.addColumn('Transactions', 'userId', {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'Users', // name of Target model
				key: 'id', // key in Target model that we're referencing
			},
		});
	},

	async down(queryInterface, Sequelize) {
		/**
		 * Add reverting commands here.
		 *
		 * Example:
		 * await queryInterface.dropTable('users');
		 */
		return queryInterface.removeColumn('Transactions', 'userId');
	},
};
