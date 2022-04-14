import { IsNotEmpty, MaxLength } from 'class-validator';

// export class CreateTaskDto {
//   @MaxLength(255, {
//     message: 'タスク名は255文字以内で入力してください',
//   })
//   name: string;
// }

export class CreateTaskDto {
  // @IsNotEmpty()
  @MaxLength(255, {
    message: 'タスク名は255文字以内で入力してください',
  })
  name: string;
}
