import Vue from 'vue';
import repoTab from '~/repo/repo_tab.vue';

describe('RepoTab', () => {
  function createComponent(propsData) {
    const RepoTab = Vue.extend(repoTab);

    return new RepoTab({
      propsData,
    }).$mount();
  }

  it('renders a close link and a name link', () => {
    const tab = {
      loading: false,
      url: 'url',
      name: 'name',
    };
    const vm = createComponent({
      tab,
    });
    const close = vm.$el.querySelector('.close');
    const name = vm.$el.querySelector(`a[title="${tab.url}"]`)

    spyOn(vm, 'xClicked');
    spyOn(vm, 'tabClicked');

    expect(close.querySelector('.fa-times')).toBeTruthy();
    expect(name.textContent).toEqual(tab.name);

    close.click();
    name.click();

    expect(vm.xClicked).toHaveBeenCalledWith(tab);
    expect(vm.tabClicked).toHaveBeenCalledWith(tab);
  });

  it('renders a spinner if tab is loading', () => {
    const tab = {
      loading: true,
      url: 'url',
    };
    const vm = createComponent({
      tab,
    });
    const close = vm.$el.querySelector('.close');
    const name = vm.$el.querySelector(`a[title="${tab.url}"]`);

    expect(close).toBeFalsy();
    expect(name).toBeFalsy();
    expect(vm.$el.querySelector('.fa.fa-spinner.fa-spin')).toBeTruthy();
  });

  it('renders an fa-circle icon if tab is changed', () => {
    const tab = {
      loading: false,
      url: 'url',
      name: 'name',
      changed: true,
    };
    const vm = createComponent({
      tab,
    });

    expect(vm.$el.querySelector('.close .fa-circle')).toBeTruthy();
  });
});
