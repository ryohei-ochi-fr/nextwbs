import { Column, PrimaryGeneratedColumn, Entity } from 'typeorm';

@Entity('tasks')
export class Task {
  @PrimaryGeneratedColumn({
    comment: 'タスクID(TaskId)',
  })
  readonly id: number;

  @Column('varchar', { comment: 'タスク名(TaskName)' })
  name: string;

  constructor(name: string) {
    this.name = name;
  }
}
