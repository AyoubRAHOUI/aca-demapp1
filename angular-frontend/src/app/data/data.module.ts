import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { SharedModule } from '../shared/shared.module';
import { DataComponent } from './pages/data/data.component';



@NgModule({
  declarations: [
    DataComponent
  ],
  imports: [
    CommonModule,
    HttpClientModule,
    SharedModule,
  ]
})
export class DataModule { }
