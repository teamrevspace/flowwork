export enum ResponseStatus {
  Waiting,
  Ready,
  SuccessfullyAdded,
  SuccessfullyDeleted,
  AddFailed,
  DeleteFailed,
  AlreadyExists,
  NotFound,
  InvalidFormat,
}

export interface Session {
  description: string;
  name: string;
  password: string;
  userIds: Array<string>;
}
