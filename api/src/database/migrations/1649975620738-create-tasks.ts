import {MigrationInterface, QueryRunner} from "typeorm";

export class createTasks1649975620738 implements MigrationInterface {
    name = 'createTasks1649975620738'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "tasks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "person" varchar NOT NULL, "jsDate" varchar NOT NULL, "jeDate" varchar NOT NULL, "progress" varchar NOT NULL, "parent" varchar NOT NULL)`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "tasks"`);
    }

}
