import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { NotnullPipe } from './pipes/notnull.pipe';
import { PrimengModule } from './primeng/primeng.module';



@NgModule({
  declarations: [NotnullPipe],
  imports: [
    CommonModule,
    PrimengModule
  ],
  exports: [
    CommonModule,
    PrimengModule,
    NotnullPipe
  ]
})
export class SharedModule { }
