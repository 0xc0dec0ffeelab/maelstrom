ARG IMAGE_BASE=clojure
ARG BUILD_IMAGE=${IMAGE_BASE}:temurin-17-lein-bookworm
ARG RUN_IMAGE=${IMAGE_BASE}:temurin-17-lein-bookworm-slim

FROM ${BUILD_IMAGE} AS build
WORKDIR /maelstrom

COPY project.clj .
COPY src src

RUN lein deps && lein uberjar

RUN mv target/maelstrom*standalone.jar maelstrom.jar

FROM ${RUN_IMAGE} AS run
WORKDIR /maelstrom

RUN apt-get update && apt-get install -y \
    gnuplot \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /maelstrom/maelstrom.jar .

USER root

ENTRYPOINT ["java", "-Djava.awt.headless=true", "-jar", "/maelstrom/maelstrom.jar"]
