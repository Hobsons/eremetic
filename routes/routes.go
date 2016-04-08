package routes

import (
	"encoding/json"
	"html/template"
	"net/http"
	"strings"

	"github.com/Sirupsen/logrus"
	"github.com/elazarl/go-bindata-assetfs"
	"github.com/gorilla/mux"
	"github.com/Hobsons/eremetic/assets"
	"github.com/Hobsons/eremetic/handler"
	"github.com/Hobsons/eremetic/types"
	"github.com/prometheus/client_golang/prometheus"
)

// Create is used to create a new router
func Create(scheduler types.Scheduler) *mux.Router {
	routes := types.Routes{
		types.Route{
			Name:    "AddTask",
			Method:  "POST",
			Pattern: "/task",
			Handler: handler.AddTask(scheduler),
		},
		types.Route{
			Name:    "Status",
			Method:  "GET",
			Pattern: "/task/{taskId}",
			Handler: handler.GetTaskInfo(scheduler),
		},
	}

	router := mux.NewRouter().StrictSlash(true)
	for _, route := range routes {
		router.
			Methods(route.Method).
			Path(route.Pattern).
			Name(route.Name).
			Handler(prometheus.InstrumentHandler(route.Name, route.Handler))
	}

	router.
		Methods("GET").
		Path("/metrics").
		Name("Metrics").
		Handler(prometheus.Handler())

	router.
		Methods("GET").
		Path("/").
		Name("Index").
		HandlerFunc(indexHandler)

	router.PathPrefix("/static/").
		Handler(
		http.StripPrefix(
			"/static/", http.FileServer(
				&assetfs.AssetFS{Asset: assets.Asset, AssetDir: assets.AssetDir, AssetInfo: assets.AssetInfo, Prefix: "static"})))

	router.NotFoundHandler = http.HandlerFunc(notFound)

	return router
}

func notFound(w http.ResponseWriter, r *http.Request) {
	if strings.Contains(r.Header.Get("Accept"), "text/html") {
		src, _ := assets.Asset("templates/error_404.html")
		tpl, err := template.New("404").Parse(string(src))
		if err == nil {
			tpl.Execute(w, nil)
			return
		}
		logrus.WithError(err).WithField("template", "error_404.html").Error("Unable to load template")
	}

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusNotFound)
	json.NewEncoder(w).Encode(nil)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	if strings.Contains(r.Header.Get("Accept"), "text/html") {
		src, _ := assets.Asset("templates/index.html")
		tpl, err := template.New("index").Parse(string(src))
		if err == nil {
			tpl.Execute(w, nil)
			return
		}
		logrus.WithError(err).WithField("template", "index.html").Error("Unable to load template")
	}

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusNoContent)
	json.NewEncoder(w).Encode(nil)
}
