import {MigrationInterface, QueryRunner} from "typeorm";

export class createTasks1649975933554 implements MigrationInterface {
    name = 'createTasks1649975933554'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "temporary_tasks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "person" varchar, "jsDate" varchar, "jeDate" varchar, "progress" varchar, "parent" varchar NOT NULL)`);
        await queryRunner.query(`INSERT INTO "temporary_tasks"("id", "name", "person", "jsDate", "jeDate", "progress", "parent") SELECT "id", "name", "person", "jsDate", "jeDate", "progress", "parent" FROM "tasks"`);
        await queryRunner.query(`DROP TABLE "tasks"`);
        await queryRunner.query(`ALTER TABLE "temporary_tasks" RENAME TO "tasks"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "tasks" RENAME TO "temporary_tasks"`);
        await queryRunner.query(`CREATE TABLE "tasks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "person" varchar NOT NULL, "jsDate" varchar NOT NULL, "jeDate" varchar NOT NULL, "progress" varchar NOT NULL, "parent" varchar NOT NULL)`);
        await queryRunner.query(`INSERT INTO "tasks"("id", "name", "person", "jsDate", "jeDate", "progress", "parent") SELECT "id", "name", "person", "jsDate", "jeDate", "progress", "parent" FROM "temporary_tasks"`);
        await queryRunner.query(`DROP TABLE "temporary_tasks"`);
    }

}
