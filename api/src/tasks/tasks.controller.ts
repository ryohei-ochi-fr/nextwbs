import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Header,
  UseInterceptors,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task } from './entities/task.entity';
import { LoggingInterceptor } from 'src/interceptor/logging.interceptor';
import { XmlresponseInterceptor } from 'src/interceptor/xmlresponse.interceptor';

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

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Task> {
    return await this.tasksService.findOne(+id);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.tasksService.remove(+id);
  }
}
