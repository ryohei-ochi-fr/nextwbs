import { Column, PrimaryGeneratedColumn, Entity } from 'typeorm';

@Entity('tasks')
export class Task {
  @PrimaryGeneratedColumn({
    comment: 'タスクID(TaskId)',
  })
  readonly id: number;

  @Column('varchar', { comment: 'タスク名(TaskName)' })
  name: string;

  @Column('varchar', { nullable: true, comment: '担当者' })
  person: string | null;

  @Column('varchar', { nullable: true, comment: '実績開始日' })
  jsDate: string | null;

  @Column('varchar', { nullable: true, comment: '実績終了日' })
  jeDate: string | null;

  @Column('varchar', { nullable: true, comment: '進捗率' })
  progress: string | null;

  @Column('varchar', { comment: '親タスクID' })
  parent: number;

  constructor(name: string) {
    this.name = name;
  }
}
