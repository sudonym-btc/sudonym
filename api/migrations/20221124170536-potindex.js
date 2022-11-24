'use strict';

const { DataTypes } = require('sequelize');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
	async up(queryInterface, Sequelize) {
		/**
		 * Add altering commands here.
		 *
		 * Example:
		 * await queryInterface.createTable('users', { id: Sequelize.INTEGER });
		 */
		return queryInterface
			.addColumn('PotUsers', 'index', {
				type: DataTypes.INTEGER,
			})
			.then(() =>
				queryInterface.sequelize
					.query(
						'UPDATE `PotUsers` SET `index` = (SELECT * FROM (SELECT COUNT(`id`)+1 FROM `PotUsers` AS `sub` WHERE `sub`.`id` < `PotUsers`.`id` AND `sub`.`userId` = `PotUsers`.`userId`) as `t1`);'
					)
					.then(() =>
						queryInterface.changeColumn('PotUsers', 'index', {
							type: DataTypes.INTEGER,
							allowNull: false,
						})
					)
			);
	},

	async down(queryInterface, Sequelize) {
		/**
		 * Add reverting commands here.
		 *
		 * Example:
		 * await queryInterface.dropTable('users');
		 */
		return queryInterface.removeColumn('PotUsers', 'index');
	},
};
