import hadoop from './logos/hadoop.svg'
import opensource from './logos/open-source.svg'
import kubernetes from './logos/kubernetes.svg'
import docker from './logos/docker.svg'
import linux from './logos/linux.svg'
import redis from './logos/redis.svg'
import aws from './logos/aws.svg'
import mariadb from './logos/mariadb.svg'

export default {
  particles: {
    number: {
      value: 8,
      density: {
        enable: true,
        value_area: 800,
      },
    },
    // 1b1e34
    color: {
      value: '#fff',
    },
    shape: {
      type: 'images',
      stroke: {
        width: 0,
        color: '#000',
      },
      polygon: {
        nb_sides: 6,
      },
      image: {
        src: hadoop,
        width: 50,
        height: 50,
      },
      images: [
        {
          src: opensource,
          width: 50,
          height: 50,
        },
        {
          src: kubernetes,
          width: 50,
          height: 50,
        },
        {
          src: hadoop,
          width: 50,
          height: 50,
        },
        {
          src: docker,
          width: 50,
          height: 50,
        },
        {
          src: linux,
          width: 50,
          height: 50,
        },
        {
          src: redis,
          width: 50,
          height: 50,
        },
        {
          src: aws,
          width: 50,
          height: 50,
        },
        {
          src: mariadb,
          width: 50,
          height: 50,
        },
      ],
    },
    opacity: {
      value: 0.3,
      random: true,
      anim: {
        enable: true,
        speed: 1,
        opacity_min: 0.1,
        sync: false,
      },
    },
    size: {
      value: 80,
      random: false,
      anim: {
        enable: true,
        speed: 4,
        size_min: 40,
        sync: false,
      },
    },
    line_linked: {
      enable: true,
      distance: 200,
      color: '#ffffff',
      opacity: 1,
      width: 2,
    },
    move: {
      enable: true,
      speed: 10,
      direction: 'none',
      random: false,
      straight: false,
      out_mode: 'out',
      bounce: false,
      attract: {
        enable: false,
        rotateX: 600,
        rotateY: 1200,
      },
    },
  },
  interactivity: {
    detect_on: 'canvas',
    events: {
      onhover: {
        enable: false,
        mode: 'grab',
      },
      onclick: {
        enable: false,
        mode: 'push',
      },
      resize: true,
    },
    modes: {
      grab: {
        distance: 400,
        line_linked: {
          opacity: 1,
        },
      },
      bubble: {
        distance: 400,
        size: 135,
        duration: 2,
        opacity: 8,
        speed: 3,
      },
      repulse: {
        distance: 200,
        duration: 0.4,
      },
      push: {
        particles_nb: 4,
      },
      remove: {
        particles_nb: 2,
      },
    },
  },
  retina_detect: true,
  // fps_limit: 100,
}
