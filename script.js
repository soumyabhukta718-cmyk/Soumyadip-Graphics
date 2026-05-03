const upiId = "7865007219@kotak811";
const payeeName = "Soumyadip Bhukta";
const screenshotWhatsApp = "917865007219";
const latestOrderKey = "soumyadipGraphicsLatestOrder";
const allOrdersKey = "soumyadipGraphicsOrders";

const state = {
  selectedService: "",
  selectedAmount: "0",
  selectedDisplay: "Rs 0",
};

function initPageLoader() {
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return;
  }

  document.body.classList.add("is-loading");
  const loader = document.createElement("div");
  loader.className = "page-loader";
  loader.setAttribute("aria-hidden", "true");
  loader.innerHTML = '<span class="loader-mark"></span>';
  document.body.prepend(loader);

  const hideLoader = () => {
    loader.classList.add("hidden");
    document.body.classList.remove("is-loading");
    window.setTimeout(() => loader.remove(), 800);
  };

  if (document.readyState === "complete") {
    window.setTimeout(hideLoader, 450);
  } else {
    window.addEventListener("load", () => window.setTimeout(hideLoader, 450), { once: true });
  }
}

function qs(selector, parent = document) {
  return parent.querySelector(selector);
}

function qsa(selector, parent = document) {
  return [...parent.querySelectorAll(selector)];
}

function formatAmount(amount) {
  const numericAmount = Number(amount);
  if (!numericAmount) {
    return "Quote Required";
  }

  return `Rs ${numericAmount.toLocaleString("en-IN")}`;
}

function makeOrderId() {
  const stamp = Date.now().toString(36).toUpperCase();
  const random = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `SG-${stamp}-${random}`;
}

function readLatestOrder() {
  try {
    return JSON.parse(localStorage.getItem(latestOrderKey) || "null");
  } catch (error) {
    return null;
  }
}

function saveOrder(order) {
  let orders = [];
  try {
    orders = JSON.parse(localStorage.getItem(allOrdersKey) || "[]");
  } catch (error) {
    orders = [];
  }

  orders.unshift(order);
  localStorage.setItem(allOrdersKey, JSON.stringify(orders.slice(0, 40)));
  localStorage.setItem(latestOrderKey, JSON.stringify(order));
}

function makePaymentLink(label, amount, orderId = "") {
  const params = new URLSearchParams({
    pa: upiId,
    pn: payeeName,
    cu: "INR",
    tn: orderId ? `${orderId} - ${label}` : label,
  });

  if (Number(amount) > 0) {
    params.set("am", amount);
  }

  return `upi://pay?${params.toString()}`;
}

function makeWhatsAppLink(order) {
  const text = [
    "New design order",
    `Order ID: ${order.orderId || "Not generated"}`,
    `Name: ${order.name || "Client"}`,
    `Phone: ${order.phone || "Not provided"}`,
    `Service: ${order.service}`,
    `Amount: ${formatAmount(order.amount)}`,
    `Details: ${order.details || "Payment screenshot attached."}`,
  ].join("\n");

  return `https://wa.me/${screenshotWhatsApp}?text=${encodeURIComponent(text)}`;
}

function initRevealAnimations() {
  const revealItems = qsa(".reveal");
  if (!revealItems.length) {
    return;
  }

  const styles = ["reveal-rise", "reveal-zoom", "reveal-slide", "reveal-soft"];
  revealItems.forEach((item, index) => {
    item.classList.add(styles[index % styles.length]);
    item.style.setProperty("--reveal-delay", `${Math.min(index % 6, 5) * 70}ms`);
  });

  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible");
          revealObserver.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.18,
      rootMargin: "0px 0px -8% 0px",
    }
  );

  revealItems.forEach((item) => revealObserver.observe(item));
}

function createParticles(target, count, className = "magic-particle") {
  if (!target) {
    return;
  }

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return;
  }

  const isSmallScreen = window.matchMedia("(max-width: 680px)").matches;
  const total = isSmallScreen ? Math.ceil(count * 0.24) : count;

  for (let index = 0; index < total; index += 1) {
    const particle = document.createElement("span");
    particle.className = className;
    particle.style.left = `${Math.random() * 100}%`;
    particle.style.animationDelay = `${Math.random() * 8}s`;
    particle.style.animationDuration = `${7 + Math.random() * 8}s`;
    particle.style.opacity = `${0.25 + Math.random() * 0.65}`;
    target.appendChild(particle);
  }
}

function initParticles() {
  createParticles(qs("[data-particles]"), 58);
  createParticles(qs("[data-particles-deep]"), 36, "magic-particle deep-particle");
  createParticles(qs("[data-payment-particles]"), 38, "magic-particle payment-particle");
}

function initLightbox() {
  const imageLightbox = qs(".image-lightbox");
  const lightboxImage = imageLightbox ? qs("img", imageLightbox) : null;
  const closeLightboxButton = qs("[data-close-lightbox]");

  qsa(".portfolio-item img").forEach((image) => {
    image.loading = "lazy";
    image.decoding = "async";
  });

  function closeLightbox() {
    if (!imageLightbox || !lightboxImage) {
      return;
    }

    imageLightbox.classList.remove("active");
    imageLightbox.setAttribute("aria-hidden", "true");
    lightboxImage.src = "";
    document.body.classList.remove("modal-open");
  }

  qsa(".portfolio-item").forEach((item) => {
    item.addEventListener("click", () => {
      if (!imageLightbox || !lightboxImage) {
        return;
      }

      lightboxImage.src = item.dataset.full;
      imageLightbox.classList.add("active");
      imageLightbox.setAttribute("aria-hidden", "false");
      document.body.classList.add("modal-open");
    });
  });

  if (imageLightbox) {
    imageLightbox.addEventListener("click", (event) => {
      if (event.target === imageLightbox) {
        closeLightbox();
      }
    });
  }

  if (closeLightboxButton) {
    closeLightboxButton.addEventListener("click", closeLightbox);
  }

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && imageLightbox && imageLightbox.classList.contains("active")) {
      closeLightbox();
    }
  });
}

function updatePaymentModal(order) {
  const selectedPackage = qs("#selectedPackage");
  const selectedAmount = qs("#selectedAmount");
  const selectedOrderId = qs("#selectedOrderId");
  const selectedClientName = qs("#selectedClientName");
  const directUpiLink = qs("#directUpiLink");
  const modalWhatsAppLink = qs("#modalWhatsAppLink");

  if (!selectedPackage || !selectedAmount || !directUpiLink || !modalWhatsAppLink) {
    return;
  }

  selectedPackage.textContent = order.service;
  selectedAmount.textContent = formatAmount(order.amount);
  directUpiLink.href = makePaymentLink(order.service, order.amount, order.orderId);
  modalWhatsAppLink.href = makeWhatsAppLink(order);

  if (selectedOrderId) {
    selectedOrderId.textContent = order.orderId || "Direct Package";
  }

  if (selectedClientName) {
    selectedClientName.textContent = order.name || "Package Client";
  }
}

function openPaymentModal(order) {
  const paymentModal = qs(".payment-modal");
  if (!paymentModal) {
    return;
  }

  updatePaymentModal(order);
  paymentModal.classList.add("active");
  paymentModal.setAttribute("aria-hidden", "false");
  document.body.classList.add("modal-open");
}

function closePaymentModal() {
  const paymentModal = qs(".payment-modal");
  if (!paymentModal) {
    return;
  }

  paymentModal.classList.remove("active");
  paymentModal.setAttribute("aria-hidden", "true");
  document.body.classList.remove("modal-open");
}

function initPaymentButtons() {
  qsa(".pay-trigger").forEach((button) => {
    button.addEventListener("click", () => {
      const order = {
        orderId: makeOrderId(),
        name: "Package Client",
        phone: "",
        service: button.dataset.package,
        amount: button.dataset.amount,
        details: "Monthly package order",
        createdAt: new Date().toISOString(),
      };
      saveOrder(order);
      openPaymentModal(order);
    });
  });

  qsa("[data-close-payment]").forEach((button) => {
    button.addEventListener("click", closePaymentModal);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && qs(".payment-modal.active")) {
      closePaymentModal();
    }
  });
}

function initOrderModal() {
  const orderModal = qs(".order-modal");
  const orderForm = qs("#quickOrderForm");
  const selectedService = qs("#orderSelectedService");

  function closeOrderModal() {
    if (!orderModal) {
      return;
    }

    orderModal.classList.remove("active");
    orderModal.setAttribute("aria-hidden", "true");
    document.body.classList.remove("modal-open");
  }

  qsa(".order-trigger").forEach((button) => {
    button.addEventListener("click", () => {
      state.selectedService = button.dataset.service;
      state.selectedAmount = button.dataset.amount;
      state.selectedDisplay = formatAmount(button.dataset.amount);

      if (selectedService) {
        selectedService.textContent = `${state.selectedService} - ${state.selectedDisplay}`;
      }

      if (orderModal) {
        orderModal.classList.add("active");
        orderModal.setAttribute("aria-hidden", "false");
        document.body.classList.add("modal-open");
        qs("input", orderModal)?.focus();
      }
    });
  });

  qsa("[data-close-order]").forEach((button) => {
    button.addEventListener("click", closeOrderModal);
  });

  if (orderForm) {
    orderForm.addEventListener("submit", (event) => {
      event.preventDefault();
      const formData = new FormData(orderForm);
      const order = {
        orderId: makeOrderId(),
        name: formData.get("name").trim(),
        phone: formData.get("phone").trim(),
        service: state.selectedService,
        amount: state.selectedAmount,
        details: formData.get("details").trim(),
        createdAt: new Date().toISOString(),
      };

      saveOrder(order);
      closeOrderModal();
      openPaymentModal(order);
      orderForm.reset();
    });
  }

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && orderModal && orderModal.classList.contains("active")) {
      closeOrderModal();
    }
  });
}

function initOrderModeToggle() {
  const buttons = qsa("[data-order-mode]");
  const panels = qsa("[data-order-panel]");

  function setMode(mode, shouldScroll = true) {
    buttons.forEach((item) => item.classList.toggle("active", item.dataset.orderMode === mode));
    panels.forEach((panel) => panel.classList.toggle("active", panel.dataset.orderPanel === mode));

    if (shouldScroll) {
      qs(`[data-order-panel="${mode}"]`)?.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      setMode(button.dataset.orderMode);
    });
  });

  qsa('a[href="#packages-main"]').forEach((link) => {
    link.addEventListener("click", () => setMode("package", false));
  });

  qsa('a[href="#services"]').forEach((link) => {
    link.addEventListener("click", () => setMode("single", false));
  });
}

function initSavedOrderPreview() {
  const card = qs("#savedOrderCard");
  const title = qs("#savedOrderTitle");
  const meta = qs("#savedOrderMeta");
  const order = readLatestOrder();

  if (!card || !title || !meta || !order) {
    return;
  }

  card.hidden = false;
  title.textContent = `${order.service} - ${formatAmount(order.amount)}`;
  meta.textContent = `${order.orderId} | ${order.name || "Client"} | ${order.phone || "Phone not added"}`;

  qs("#payLatestOrder")?.addEventListener("click", () => openPaymentModal(order));
}

function initButtonRipples() {
  qsa(".btn, .mode-option").forEach((button) => {
    button.addEventListener("click", (event) => {
      const ripple = document.createElement("span");
      const rect = button.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      ripple.className = "ripple";
      ripple.style.width = `${size}px`;
      ripple.style.height = `${size}px`;
      ripple.style.left = `${event.clientX - rect.left - size / 2}px`;
      ripple.style.top = `${event.clientY - rect.top - size / 2}px`;
      button.appendChild(ripple);
      ripple.addEventListener("animationend", () => ripple.remove());

      button.classList.add("is-clicking");
      window.setTimeout(() => button.classList.remove("is-clicking"), 180);
    });
  });
}

function initCursorGlow() {
  if (window.matchMedia("(pointer: coarse)").matches) {
    return;
  }

  const glow = document.createElement("span");
  glow.className = "cursor-glow";
  document.body.appendChild(glow);

  let mouseX = -400;
  let mouseY = -400;
  let currentX = mouseX;
  let currentY = mouseY;

  function animateGlow() {
    currentX += (mouseX - currentX) * 0.16;
    currentY += (mouseY - currentY) * 0.16;
    glow.style.transform = `translate3d(${currentX}px, ${currentY}px, 0)`;
    requestAnimationFrame(animateGlow);
  }

  window.addEventListener("pointermove", (event) => {
    mouseX = event.clientX;
    mouseY = event.clientY;
    glow.classList.add("active");
  });

  window.addEventListener("pointerleave", () => glow.classList.remove("active"));
  animateGlow();
}

function initTiltCards() {
  if (window.matchMedia("(pointer: coarse), (max-width: 860px)").matches) {
    return;
  }

  qsa(".service-card, .package-card").forEach((card) => {
    card.addEventListener("pointermove", (event) => {
      const rect = card.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      card.style.transform = `perspective(1000px) rotateX(${y * -8}deg) rotateY(${x * 8}deg) translateY(-8px) scale(1.01)`;
    });

    card.addEventListener("pointerleave", () => {
      card.style.transform = "";
    });
  });
}

function initParallax() {
  const hero = qs(".portfolio-hero picture img") || qs(".landing-logo");
  if (!hero || window.matchMedia("(max-width: 680px)").matches) {
    return;
  }

  window.addEventListener("pointermove", (event) => {
    const x = (event.clientX / window.innerWidth - 0.5) * 12;
    const y = (event.clientY / window.innerHeight - 0.5) * 12;
    document.documentElement.style.setProperty("--parallax-x", `${x}px`);
    document.documentElement.style.setProperty("--parallax-y", `${y}px`);
  });
}

initPageLoader();
initRevealAnimations();
initParticles();
initLightbox();
initPaymentButtons();
initOrderModal();
initOrderModeToggle();
initSavedOrderPreview();
initButtonRipples();
initCursorGlow();
initTiltCards();
initParallax();
