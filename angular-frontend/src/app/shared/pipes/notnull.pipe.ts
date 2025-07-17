import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'notnull',
})
export class NotnullPipe implements PipeTransform {
  transform(value: any): any {
    if (typeof value === 'undefined' || value === null) {
      return [];
    }

    return value;
  }
}
