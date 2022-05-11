import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task } from './entities/task.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task) private taskRepository: Repository<Task>,
  ) {}

  async createId(createTaskDto: CreateTaskDto): Promise<{ taskId: string }> {
    const task = await this.taskRepository
      .save({
        name: createTaskDto.name,
        parent: 0,
      })
      .catch((e) => {
        throw new InternalServerErrorException(
          `[${e.message}]タスクIDの発番に失敗しました。`,
        );
      });

    console.log(task);
    return { taskId: task.id.toString() };
  }

  async create(createTaskDto: CreateTaskDto): Promise<{ message: string }> {
    await this.taskRepository
      .save({
        name: createTaskDto.name,
      })
      .catch((e) => {
        throw new InternalServerErrorException(
          `[${e.message}]タスクの登録に失敗しました。`,
        );
      });
    return { message: 'タスクの登録に成功しました。' };
  }

  async updateTask(
    id: number,
    updateTaskDto: UpdateTaskDto,
  ): Promise<{ message: string }> {
    if (!id) throw new NotFoundException('TaskID が指定されていません。');
    await this.taskRepository
      .update(id, {
        name: updateTaskDto.name,
        person: updateTaskDto.person,
        jsDate: updateTaskDto.jsDate,
        jeDate: updateTaskDto.jeDate,
        progress: updateTaskDto.progress,
        parent: updateTaskDto.parent,
      })
      .catch((e) => {
        throw new InternalServerErrorException(
          `[${e.message}]TaskID ${id} の更新に失敗しました。`,
        );
      });
    return { message: `200` };
  }

  async update(
    id: number,
    updateTaskDto: UpdateTaskDto,
  ): Promise<{ message: string }> {
    if (!id) throw new NotFoundException('TaskID が指定されていません。');
    await this.taskRepository
      .update(id, {
        name: updateTaskDto.name,
      })
      .catch((e) => {
        throw new InternalServerErrorException(
          `[${e.message}]TaskID ${id} の更新に失敗しました。`,
        );
      });
    return { message: `TaskID ${id} の更新に成功しました。` };
  }

  async remove(id: number): Promise<{ message: string }> {
    if (!id) throw new NotFoundException('TaskID が指定されていません。');
    await this.taskRepository.delete(id).catch((e) => {
      throw new InternalServerErrorException(
        `[${e.message}]TaskID ${id} の削除に失敗しました。`,
      );
    });
    return { message: `TaskID ${id} の削除に成功しました。` };
  }

  async findAll(): Promise<Task[]> {
    return await this.taskRepository.query(
      'select id, name, person' +
        ", strftime('%m/%d', date('2022-04-01', printf('%d days',jsDate - 44652))) as jsDate" +
        ", strftime('%m/%d', date('2022-04-01', printf('%d days',jeDate - 44652))) as jeDate" +
        ", printf('%d%',progress * 100) as progress" +
        ', parent ' +
        'from tasks ' +
        'where person is not null and progress < 1',
    );
  }

  async findAllParentIs10(): Promise<Task[]> {
    return await this.taskRepository.query(
      'select id, name, person' +
        ", strftime('%m/%d', date('2022-04-01', printf('%d days',jsDate - 44652))) as jsDate" +
        ", strftime('%m/%d', date('2022-04-01', printf('%d days',jeDate - 44652))) as jeDate" +
        ", printf('%d%',progress * 100) as progress" +
        ', parent ' +
        'from tasks ' +
        'where parent = 10',
    );
  }
  async findOne(id: number): Promise<Task> {
    if (!id) throw new NotFoundException('TaskID が指定されていません。');
    return await this.taskRepository.findOne(id);
  }
  async findPerson(person: string): Promise<Task[]> {
    return await this.taskRepository.query(
      'select id, name, person' +
        ", strftime('%m/%d', date('2022-04-01', printf('%d days',jsDate - 44652))) as jsDate" +
        ", strftime('%m/%d', date('2022-04-01', printf('%d days',jeDate - 44652))) as jeDate" +
        ", printf('%d%',progress * 100) as progress" +
        ', parent ' +
        'from tasks ' +
        "where person = '" +
        person +
        "'",
    );
  }
}
