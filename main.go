package main

import (
	"fmt"
	"log"
	"net/http"

	"database/sql"

	env "github.com/Netflix/go-env"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	_ "github.com/mattn/go-sqlite3"
)

type Environment struct {
	SQLiteDB string `env:"SQLITE_DB_PATH,required=true"`
}

func main() {
	var environment Environment
	_, err := env.UnmarshalFromEnviron(&environment)
	if err != nil {
		log.Fatal(err)
	}

	dsn := fmt.Sprintf("%s?_fk=true", environment.SQLiteDB)
	db, err := sql.Open("sqlite3", dsn)
	if err != nil {
		log.Fatal(err.Error())
	}

	rows, err := db.Query("SELECT id,title FROM events")
	if err != nil {
		log.Fatal(err.Error())
	}

	for rows.Next() {
		var id int
		var title string
		err := rows.Scan(&id, &title)
		if err != nil {
			log.Fatal(err.Error())
		}
		log.Println(id, title)
	}
	if rows.Err() != nil {
		log.Fatal(rows.Err().Error())
	}

	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome"))
	})
	http.ListenAndServe(":3000", r)
}
