import cats.*
import cats.effect.*
import cats.syntax.all.*
import com.comcast.ip4s.*
import org.http4s.HttpRoutes
import org.http4s.dsl.Http4sDsl
import org.http4s.ember.server.EmberServerBuilder

class HttpApp[F[_]: Monad] extends Http4sDsl[F]:

  val routes = HttpRoutes.of[F]:
    case GET -> Root / "alive" => Ok("I'm alive")

  val app = routes.orNotFound

object Main extends IOApp.Simple:

  val h = host"localhost"
  val p = port"8080"

  def run: IO[Unit] = EmberServerBuilder
    .default[IO]
    .withHost(h)
    .withPort(p)
    .withHttpApp(HttpApp[IO].app)
    .build
    .evalTap(_ => IO.println(s"server listening on http://$h:$p..."))
    .useForever
