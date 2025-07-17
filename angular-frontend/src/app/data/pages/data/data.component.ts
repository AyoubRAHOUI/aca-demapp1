import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { EMPTY, Observable, map, tap } from 'rxjs';

@Component({
  selector: 'app-data',
  templateUrl: './data.component.html',
  styleUrls: ['./data.component.scss']
})
export class DataComponent implements OnInit {

  public jedis: Observable<any[] | null> = EMPTY;

  constructor(private httpClient: HttpClient) { }

  ngOnInit(): void {
    this.jedis = this.httpClient.get<any>('api/data').pipe(
      tap(result => {
        console.log(result);
      }),
      map(result => result.results),
    );
  }
}

