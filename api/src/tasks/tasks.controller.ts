import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseInterceptors,
  Res,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task } from './entities/task.entity';
import { LoggingInterceptor } from 'src/interceptor/logging.interceptor';
import { Response } from 'express';

@UseInterceptors(LoggingInterceptor)
@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post()
  async create(
    @Body() createTaskDto: CreateTaskDto,
  ): Promise<{ message: string }> {
    return await this.tasksService.create(createTaskDto);
  }

  @Get(':taskName/:key')
  async createId(
    @Param('taskName') taskname: string,
    @Param('key') key: string,
  ): Promise<{ taskId: string }> {
    const createTaskDto: CreateTaskDto = {
      name: taskname,
    };
    return await this.tasksService.createId(createTaskDto);
  }

  @Get('/xml/:taskName/:key')
  async createIdXml(
    @Param('taskName') taskname: string,
    @Param('key') key: string,
    @Res() res: Response,
  ) {
    const createTaskDto: CreateTaskDto = {
      name: taskname,
    };

    const json = await this.tasksService.createId(createTaskDto);

    res.set('Content-Type', 'text/xml; charset=UTF-8');
    res.send('<result><taskId>' + json.taskId + '</taskId></result>');
  }

  @Get('/xml/:taskId/:taskName/:person/:jsDate/:jeDate/:progress/:parent')
  async updateTaskXml(
    @Param('taskId') taskid: string,
    @Param('taskName') taskname: string,
    @Param('person') person: string,
    @Param('jsDate') jsDate: string,
    @Param('jeDate') jeDate: string,
    @Param('progress') progress: string,
    @Param('parent') parent: number,
    @Res() res: Response,
  ) {
    const updateTaskDto: UpdateTaskDto = {
      name: taskname,
      person: person,
      jsDate: jsDate,
      jeDate: jeDate,
      progress: progress,
      parent: parent,
    };

    const json = await this.tasksService.updateTask(+taskid, updateTaskDto);

    res.set('Content-Type', 'text/xml; charset=UTF-8');
    res.send('<result><code>' + json.message + '</code></result>');
  }

  @Get(':taskId/:taskName/:person/:jsDate/:jeDate/:progress/:parent')
  async updateTask(
    @Param('taskId') taskid: string,
    @Param('taskName') taskname: string,
    @Param('person') person: string,
    @Param('jsDate') jsDate: string,
    @Param('jeDate') jeDate: string,
    @Param('progress') progress: string,
    @Param('parent') parent: number,
  ): Promise<{ message: string }> {
    const updateTaskDto: UpdateTaskDto = {
      name: taskname,
      person: person,
      jsDate: jsDate,
      jeDate: jeDate,
      progress: progress,
      parent: parent,
    };
    return await this.tasksService.updateTask(+taskid, updateTaskDto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ): Promise<{ message: string }> {
    return await this.tasksService.update(+id, updateTaskDto);
  }

  @Get()
  async findAll(): Promise<Task[]> {
    return await this.tasksService.findAll();
  }

  @Get('/emergency')
  async findAllParentIs10(): Promise<Task[]> {
    return await this.tasksService.findAllParentIs10();
  }

  // @Get(':id')
  // async findOne(@Param('id') id: string): Promise<Task> {
  //   return await this.tasksService.findOne(+id);
  // }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.tasksService.remove(+id);
  }
}
