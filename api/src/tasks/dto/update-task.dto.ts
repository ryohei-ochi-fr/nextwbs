import { MaxLength } from 'class-validator';

export class UpdateTaskDto {
  @MaxLength(255, {
    message: 'タスク名は255文字以内で入力してください',
  })
  name: string;
  person: string | null;
  jsDate: string | null;
  jeDate: string | null;
  progress: string | null;
  parent: number;
}
