PROJ=${1-skel}
PKG=${PROJ}
mkdir -p ~/${PROJ}/src/{main,test}/{java,resources}/${PKG}/

(cd ~/${PROJ}/
echo ".classpath
.gradle
.idea
.project
.settings
bin
build
gradle
target
" > .gitignore

echo "<?xml version=\"1.0\"?>
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>${PROJ}</groupId>
  <artifactId>${PROJ}</artifactId>
  <version>1.0</version>
  <repositories/>
  <dependencies>
    <dependency><groupId>com.fasterxml.jackson.core</groupId><artifactId>jackson-databind</artifactId><version>LATEST</version></dependency>
    <dependency><groupId>commons-logging</groupId><artifactId>commons-logging</artifactId><version>LATEST</version></dependency>
    <dependency><groupId>javax.mail</groupId><artifactId>mail</artifactId><version>LATEST</version></dependency>
    <dependency><groupId>junit</groupId><artifactId>junit</artifactId><version>LATEST</version></dependency>
    <dependency><groupId>log4j</groupId><artifactId>log4j</artifactId><version>LATEST</version></dependency>
    <dependency><groupId>org.apache.httpcomponents</groupId><artifactId>httpclient</artifactId><version>LATEST</version></dependency>
  </dependencies>
  <build>
    <resources>
      <resource><directory>src/main/resources</directory><filtering>true</filtering></resource>
    </resources>
    <plugins>
      <plugin>
        <artifactId>maven-assembly-plugin</artifactId>
        <configuration>
          <descriptorRefs><descriptorRef>jar-with-dependencies</descriptorRef></descriptorRefs>
          <archive><manifest><mainClass>${PKG}.Main</mainClass></manifest></archive>
        </configuration>
      </plugin>
      <plugin>
        <artifactId>maven-compiler-plugin</artifactId>
        <configuration>
          <encoding>UTF-8</encoding>
          <source>12</source>
          <target>12</target>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
" | sed "s/\${PKG}/${PKG}/g" | sed "s/\${PROJ}/${PROJ}/g" > pom.xml

echo "### How to run this?
mvn eclipse:clean eclipse:eclipse install assembly:single && java -jar target/${PROJ}-1.0-jar-with-dependencies.jar

### How to rename this?
find -type f | xargs sed s/${PROJ}/newname/g
" > README.md

echo "package ${PKG};

public class Main {

public static void main(String[] args) {
}

}
" | sed "s/\${PROJ}/${PROJ}/g" > src/main/java/${PKG}/Main.java

echo "package ${PKG};

import org.junit.Test;

public class UnitTest {

@Test
public void test() {
}

}
" > src/test/java/${PKG}/UnitTest.java

mvn eclipse:clean eclipse:eclipse install assembly:single
)

# ~/eclipse/eclipse ~/${PROJ}
