import cats.syntax.all.*
import cats.effect.*

object Main extends IOApp.Simple {

  def run: IO[Unit] = IO.println("hello world")

}
