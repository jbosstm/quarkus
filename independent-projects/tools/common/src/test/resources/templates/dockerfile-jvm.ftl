####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
# Before building the docker image run:
#
# mvn package
#
# Then, build the image with:
#
# docker build -f src/main/docker/Dockerfile.jvm -t quarkus/${project_artifactId}-jvm .
#
# Then run the container using:
#
# docker run -i --rm -p 8080:8080 quarkus/${project_artifactId}-jvm
#
###
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.1

ARG JAVA_PACKAGE=java-1.8.0-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.5

# Install java and the run-java script
# Also set up permissions for user `1001`
RUN microdnf install ${JAVA_PACKAGE} \
&& microdnf clean all \
&& mkdir /deployments \
&& chown 1001 /deployments \
&& chmod "g+rwX" /deployments \
&& chown 1001:root /deployments \
&& curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh \
&& chown 1001 /deployments/run-java.sh \
&& chmod 550 /deployments/run-java.sh \
&& echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security

ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"

COPY ${build_dir}/lib/* /deployments/lib/
COPY ${build_dir}/*-runner.jar /deployments/app.jar

EXPOSE 8080
USER 1001

ENTRYPOINT [ "/deployments/run-java.sh" ]