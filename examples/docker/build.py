import os

from ml_buildkit import build_utils
from ml_buildkit.helpers import build_docker

COMPONENT_NAME = "docker-template"
DOCKER_IMAGE_PREFIX = "khulnasoft"

HERE = os.path.abspath(os.path.dirname(__file__))


def main(args: dict) -> None:
    # set current path as working dir
    os.chdir(HERE)

    version = args.get(build_utils.FLAG_VERSION)
    docker_image_prefix = args.get(build_docker.FLAG_DOCKER_IMAGE_PREFIX)

    if not docker_image_prefix:
        docker_image_prefix = DOCKER_IMAGE_PREFIX  # type: ignore

    if args.get(build_utils.FLAG_MAKE):
        build_docker.build_docker_image(COMPONENT_NAME, version, exit_on_error=True)

    if args.get(build_utils.FLAG_CHECK):
        build_docker.lint_dockerfile(exit_on_error=True)
        # TODO: the python base image currently has vulnerabilities
        # build_docker.check_image(
        #     image=build_docker.get_image_name(name=COMPONENT_NAME, tag=version),
        #     exit_on_error=True,
        # )

    if args.get(build_utils.FLAG_RELEASE):
        # TODO: commented to prevent template image to be released
        # build_docker.release_docker_image(
        #     IMAGE_NAME,
        #     version,
        #     docker_image_prefix,
        #     exit_on_error=True,
        # )
        pass


if __name__ == "__main__":
    main(build_docker.parse_arguments())
