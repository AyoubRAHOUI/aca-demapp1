import { NgModule } from '@angular/core';
import { CardModule } from 'primeng/card';
import { PanelModule } from 'primeng/panel';
import { TableModule } from 'primeng/table';


@NgModule({
  declarations: [],
  imports: [
    TableModule,
    PanelModule,
    CardModule,
  ],
  exports: [
    TableModule,
    PanelModule,
    CardModule,
  ]
})
export class PrimengModule { }
